package com.meeting.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.cloudroom.cloudroomvideosdk.model.UsrVideoId
import com.example.meetingdemo.R
import com.meeting.example.common.VideoView

/**
 * Created by zjw on 2021/12/20.
 */
class MemberVideoAdapter(val context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val memberVideoData = arrayListOf<UsrVideoId>()

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return MemberVideoHolder(
            LayoutInflater.from(context).inflate(R.layout.item_member_video, parent, false)
        )
    }

    fun setData(data: List<UsrVideoId>) {
        memberVideoData.clear()
        memberVideoData.addAll(data)
        notifyDataSetChanged()
    }

    override fun getItemCount(): Int {
        return memberVideoData.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder as MemberVideoHolder).setData(position)
    }

    inner class MemberVideoHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {

        private val videoView = itemView.findViewById<VideoView>(R.id.videoView)

        fun setData(position: Int) {
            videoView.usrVideoId = memberVideoData[position]
        }
    }
}